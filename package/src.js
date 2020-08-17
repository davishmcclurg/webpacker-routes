import Route from 'route-parser'

const reservedOptions = [
  'anchor',
  'domain',
  'host',
  'only_path',
  'original_script_name',
  'params',
  'port',
  'protocol',
  'relative_url_root',
  'script_name',
  'subdomain',
  'tld_length',
  'trailing_slash'
]

const unsupportedUrlOptions = [
  'domain',
  'subdomain',
  'tld_length'
]

const unsupportedPathOptions = [
  'original_script_name'
]

const validateOptions = (options, unsupportedOptions) => {
  Object.keys(options).forEach(option => {
    if (unsupportedOptions.includes(option)) {
      throw new Error(`Unsupported option: ${option}`)
    }
  })
}

const handlePositionalArgs = (segmentKeys, defaults, args, options) => {
  const out = {}

  if (args.length > 0) {
    const nonFormatSegmentKeysLength = segmentKeys.includes('format') ? segmentKeys.length - 1 : segmentKeys.length
    const params = segmentKeys.filter(segmentKey => {
      return !options.hasOwnProperty(segmentKey) && (args.length >= nonFormatSegmentKeysLength || !defaults.hasOwnProperty(segmentKey))
    })

    args.forEach((arg, index) => {
      const param = params[index]
      if (param != null) {
        out[param] = arg
      }
    })
  }

  return Object.assign({}, defaults, out, options)
}

const routeCache = {}
const generate = (spec, options) => {
  if (!routeCache.hasOwnProperty(spec)) {
    routeCache[spec] = new Route(spec)
  }
  const path = routeCache[spec].reverse(options)
  if (path === false) {
    throw new Error(`Unable to generate path for route: ${spec} using options: ${JSON.stringify(options)}`)
  }
  return path
}

const generatePath = (options) => {
  validateOptions(options, unsupportedPathOptions)
  const { script_name, path, trailing_slash, params, anchor } = options
  let out = ''
  if (script_name) {
    out += script_name.replace(/\/$/, '')
  }
  if (path) {
    out += path
  }
  if (trailing_slash && path.indexOf('?') !== -1) {
    out = out.replace(/\?/, '/$&')
  } else if (trailing_slash && path.indexOf('.') === -1) {
    out = out.replace(/[^\/]$|^$/, '$&/')
  }
  if (params) {
    const query = Object.keys(params).map(key => {
      return `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`
    })
    if (query.length) {
      out += `?${query.join('&')}`
    }
  }
  if (anchor) {
    out += `#${encodeURIComponent(anchor)}`
  }
  return out
}

const generateUrl = (options) => {
  validateOptions(options, unsupportedUrlOptions)
  let { host, port, protocol } = options
  const { user, password } = options
  if (!host) {
    throw new Error('Missing host')
  }
  const match = host.match(/(^[^:]+:\/\/)?(\[[^\]]+\]|[^:]+)(?::(\d+$))?/)
  if (match) {
    if (protocol == null) {
      protocol = match[1]
    }
    host = match[2]
    if (typeof port === 'undefined') {
      port = match[3]
    }
  }
  let out = ''
  if (protocol && protocol !== '//') {
    out += `${protocol.replace(/:(\/\/)?$/, '')}:`
  }
  out += '//'
  if (user && password) {
    out += `${encodeURIComponent(user)}:${encodeURIComponent(password)}@`
  }
  if (host) {
    out += host
  }
  if (port) {
    out += `:${port}`
  }
  out += generatePath(options)
  return out
}

const flattenSegmentKeys = ([_spec, segmentKeys, _defaults, parent]) => {
  return parent ? [...segmentKeys, ...flattenSegmentKeys(parent)] : segmentKeys
}

export const urlFor = ([spec, segmentKeys, defaults, parent], ...args) => {
  const lastArgOptions = (args[args.length - 1] && typeof args[args.length - 1] === 'object') ? args.pop() : {}
  let {
    user,
    password,
    script_name,
    relative_url_root,
    params = {},
    ...options
  } = handlePositionalArgs(segmentKeys, defaults, args, lastArgOptions)

  if (parent && !script_name) {
    const parentOptions = {}
    const parentSegmentKeys = flattenSegmentKeys(parent)
    for (let [key, value] of Object.entries(options)) {
      if (parentSegmentKeys.includes(key)) {
        parentOptions[key] = value
        delete options[key]
      }
    }
    script_name = pathFor(parent, parentOptions)
  }

  const nonReservedOptions = {}
  Object.keys(options).filter(option => !reservedOptions.includes(option)).forEach(option => {
    nonReservedOptions[option] = options[option]
  })

  const queryParams = {}
  Object.keys(nonReservedOptions).filter(option => !segmentKeys.includes(option) && !defaults.hasOwnProperty(option)).forEach(option => {
    queryParams[option] = nonReservedOptions[option]
  })
  Object.assign(queryParams, params)

  Object.assign(options, {
    user,
    password,
    script_name: script_name || relative_url_root,
    params: queryParams,
    path: generate(spec, nonReservedOptions)
  })

  return options.only_path ? generatePath(options) : generateUrl(options)
}

export const pathFor = ([spec, segmentKeys, defaults, parent], ...args) => urlFor([spec, segmentKeys, { only_path: true, ...defaults }, parent], ...args)

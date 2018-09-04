import Route from 'route-parser'

// fixme
const defaultUrlOptions = {}

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

const unsupportedOptions = [
  'domain',
  'original_script_name',
  'subdomain',
  'tld_length'
]

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

const pathFor = (options) => {
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

const fullUrlFor = (options) => {
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
  out += pathFor(options)
  return out
}

export const urlFor = ([spec, segmentKeys, defaults], ...args) => {
  const lastArgOptions = (args[args.length - 1] && typeof args[args.length - 1] === 'object') ? args.pop() : {}
  const positionedOptions = handlePositionalArgs(segmentKeys, defaults, args, lastArgOptions)

  const {
    user,
    password,
    script_name,
    relative_url_root,
    params = {},
    ...options
  } = Object.assign({}, defaultUrlOptions, positionedOptions)

  Object.keys(options).forEach(option => {
    if (unsupportedOptions.includes(option)) {
      throw new Error(`Unsupported option: ${option}`)
    }
  })

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

  return options.only_path ? pathFor(options) : fullUrlFor(options)
}

export const onlyPath = ([spec, segmentKeys, defaults]) => [
  spec,
  segmentKeys,
  { only_path: true, ...defaults }
]

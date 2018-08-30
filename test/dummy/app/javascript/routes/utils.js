import Route from 'route-parser'

const handlePositionalArgs = (segmentKeys, defaults, args, options) => {
  const result = {}

  if (args.length > 0) {
    let nonFormatSegmentKeysLength = segmentKeys.includes('format') ? segmentKeys.length - 1 : segmentKeys.length
    if (args.length < nonFormatSegmentKeysLength) {
      segmentKeys = segmentKeys.filter((segmentKey) => !defaults.hasOwnProperty(segmentKey))
    }
    segmentKeys = segmentKeys.filter((segmentKey) => !options.hasOwnProperty(segmentKey))

    args.forEach((arg, index) => {
      const param = segmentKeys[index]
      if (typeof param !== 'undefined') {
        result[param] = arg
      }
    })
  }

  return Object.assign({}, defaults, result, options)
}

const routes = {}
export const urlFor = (spec, segmentKeys, defaults, ...args) => {
  const route = routes[spec] || new Route(spec)
  if (typeof routes[spec] === 'undefined') {
    routes[spec] = route
  }

  const options = (args[args.length - 1] && typeof args[args.length - 1] === 'object') ? args.pop() : {}
  const params = handlePositionalArgs(segmentKeys, defaults, args, options)
  const query = Object.keys(options).filter((option) => !segmentKeys.includes(option)).map((option) => {
    return `${encodeURIComponent(option)}=${encodeURIComponent(options[option])}`
  }).join('&')

  const path = route.reverse(params)
  if (path === false) {
    throw new Error(`Unable to generate route: ${spec} using params: ${JSON.stringify(params)}`)
  }
  if (query) {
    return `${path}?${query}`
  }
  return path
}

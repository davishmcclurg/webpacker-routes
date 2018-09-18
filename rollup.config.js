import babel from 'rollup-plugin-babel';

export default {
  input: 'package/src.js',
  output: {
    file: 'package/dist.js',
    format: 'esm'
  },
  external: ['route-parser'],
  plugins: [
    babel({
      plugins: ['@babel/plugin-proposal-object-rest-spread'],
      presets: [
        [
          '@babel/preset-env',
          {
            modules: false,
            targets: '> 1%'
          }
        ]
      ]
    })
  ]
}

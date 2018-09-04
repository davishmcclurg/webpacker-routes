/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import { rails_blob_representation_path, rails_blob_representation_url } from 'routes'

console.log(
  rails_blob_representation_path({
    signed_blob_id: 'a',
    variation_key: 'b',
    filename: 'c'
  })
)

console.log(
  rails_blob_representation_url(
    'a',
    'b',
    'c',
    {
      anchor: 'someanchor',
      host: 'example.com:69',
      params: {
        x: 'y',
        z: '?'
      },
      port: 6969,
      protocol: 'https://',
      relative_url_root: '/zzz',
      trailing_slash: true
    }
  )
)

import { urlFor, onlyPath } from './utils'
const rails_blob_representation = ["/rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)", ["signed_blob_id","variation_key","filename","format"], {}]
export const rails_blob_representation_url = (...args) => urlFor(rails_blob_representation, ...args)
export const rails_blob_representation_path = (...args) => urlFor(onlyPath(rails_blob_representation), ...args)
const rails_direct_uploads = ["/rails/active_storage/direct_uploads(.:format)", ["format"], {}]
export const rails_direct_uploads_url = (...args) => urlFor(rails_direct_uploads, ...args)
export const rails_direct_uploads_path = (...args) => urlFor(onlyPath(rails_direct_uploads), ...args)
const rails_disk_service = ["/rails/active_storage/disk/:encoded_key/*filename(.:format)", ["encoded_key","filename","format"], {}]
export const rails_disk_service_url = (...args) => urlFor(rails_disk_service, ...args)
export const rails_disk_service_path = (...args) => urlFor(onlyPath(rails_disk_service), ...args)
const rails_info = ["/rails/info(.:format)", ["format"], {}]
export const rails_info_url = (...args) => urlFor(rails_info, ...args)
export const rails_info_path = (...args) => urlFor(onlyPath(rails_info), ...args)
const rails_info_properties = ["/rails/info/properties(.:format)", ["format"], {}]
export const rails_info_properties_url = (...args) => urlFor(rails_info_properties, ...args)
export const rails_info_properties_path = (...args) => urlFor(onlyPath(rails_info_properties), ...args)
const rails_info_routes = ["/rails/info/routes(.:format)", ["format"], {}]
export const rails_info_routes_url = (...args) => urlFor(rails_info_routes, ...args)
export const rails_info_routes_path = (...args) => urlFor(onlyPath(rails_info_routes), ...args)
const rails_mailers = ["/rails/mailers(.:format)", ["format"], {}]
export const rails_mailers_url = (...args) => urlFor(rails_mailers, ...args)
export const rails_mailers_path = (...args) => urlFor(onlyPath(rails_mailers), ...args)
const rails_service_blob = ["/rails/active_storage/blobs/:signed_id/*filename(.:format)", ["signed_id","filename","format"], {}]
export const rails_service_blob_url = (...args) => urlFor(rails_service_blob, ...args)
export const rails_service_blob_path = (...args) => urlFor(onlyPath(rails_service_blob), ...args)
const root = ["/", [], {}]
export const root_url = (...args) => urlFor(root, ...args)
export const root_path = (...args) => urlFor(onlyPath(root), ...args)
const update_rails_disk_service = ["/rails/active_storage/disk/:encoded_token(.:format)", ["encoded_token","format"], {}]
export const update_rails_disk_service_url = (...args) => urlFor(update_rails_disk_service, ...args)
export const update_rails_disk_service_path = (...args) => urlFor(onlyPath(update_rails_disk_service), ...args)

require 'test_helper'
require 'execjs'

class Webpacker::Routes::Test < ActiveSupport::TestCase
  delegate :root_path, :source_entry_path, :routes_path, :public_path, :to => :'Webpacker.config'

  def compile(javascript, pack: 'test.js')
    pack_file = source_entry_path.join(pack)
    pack_file.delete if pack_file.exist?
    pack_file.write(javascript)
    Webpacker::Routes.generate(Rails.application)
    return false unless Dir.chdir(root_path) { Webpacker.compile }
    public_path.join(Webpacker.manifest.lookup(pack).slice(1..-1)).read
  ensure
    pack_file.delete
  end

  def routes_execjs_context
    ExecJS.compile(compile(<<-JAVASCRIPT))
      import * as routes from 'routes'
      global.__routes__ = routes
    JAVASCRIPT
  end

  test 'generates url/path helpers' do
    context = routes_execjs_context
    assert_equal('/', context.eval('__routes__.root_path()'))
    assert_equal('http://example.com/', context.eval('__routes__.root_url({ host: "http://example.com" })'))
    assert_equal('/?foo=bar', context.eval('__routes__.root_path({ foo: "bar" })'))
  end

  test 'respects default_url_options' do
    Rails.application.default_url_options = { :host => 'https://example.com' }
    context = routes_execjs_context
    assert_equal('http://example.com/', context.eval('__routes__.root_url({ host: "http://example.com" })'))
    assert_equal('https://example.com/', context.eval('__routes__.root_url()'))
    Rails.application.config.webpacker.routes.default_url_options = { :host => 'http://example.net' }
    context = routes_execjs_context
    assert_equal('https://example.net/', context.eval('__routes__.root_url({ host: "https://example.net" })'))
    assert_equal('http://example.net/', context.eval('__routes__.root_url()'))
    Rails.application.config.webpacker.routes.default_url_options = {}
    Rails.application.default_url_options = {}
  end

  test 'camel_case' do
    Rails.application.config.webpacker.routes.camel_case = true
    context = routes_execjs_context
    assert_equal('/', context.eval('__routes__.rootPath()'))
    assert_equal('http://example.com/', context.eval('__routes__.rootUrl({ host: "http://example.com" })'))
    assert_equal('/?foo=bar', context.eval('__routes__.rootPath({ foo: "bar" })'))
    Rails.application.config.webpacker.routes.camel_case = false
  end

  test 'compilation fails for invalid route name' do
    refute compile(<<-JAVASCRIPT)
      import { invalid_url } from 'routes'
      invalid_url()
    JAVASCRIPT
  end

  test 'tree-shakes unused routes' do
    Rails.application.routes.draw do
      get '/used/for/something', as: :used
      get '/tree/shook', as: :tree_shook
    end
    output = compile(<<-JAVASCRIPT)
      import { used_path } from 'routes'
      used_path()
    JAVASCRIPT
    assert_match(/\/used\/for\/something/, output)
    assert_no_match(/\/tree\/shook/, output)
    Rails.application.reload_routes!
  end
end

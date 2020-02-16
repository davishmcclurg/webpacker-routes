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

  test 'respects relative_url_root' do
    Rails.application.config.relative_url_root = '/sub'
    context = routes_execjs_context
    assert_equal('/sub/', context.eval('__routes__.root_path()'))
    assert_equal('http://example.com/sub/', context.eval('__routes__.root_url({ host: "http://example.com" })'))
    Rails.application.config.relative_url_root = nil
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

  test 'rails engine' do
    class ::TestEngine3 < Rails::Engine; end
    class ::TestEngine2 < Rails::Engine; end
    class ::TestEngine1 < Rails::Engine; end

    ::TestEngine3.routes.draw do
      get 'bleh' => 'bleh#bleh'
    end
    ::TestEngine2.routes.draw do
      root 'root#root'
      get 'foo' => 'foo#foo'
    end
    ::TestEngine1.routes.draw do
      mount ::TestEngine2, at: 'two/:engine2_id'
      get 'bar' => 'bar#bar'
    end
    Rails.application.routes.draw do
      root 'application#index'
      mount ::TestEngine1, at: 'one/:engine1_id'
      mount ::TestEngine3, at: 'three'
      get 'baz' => 'baz#baz'
    end

    context = ExecJS.compile(compile(<<-JAVASCRIPT))
      import * as routes from 'routes'
      import * as engine1_routes from 'routes/test_engine1'
      import * as engine2_routes from 'routes/test_engine1/test_engine2'
      import * as engine3_routes from 'routes/test_engine3'
      global.__routes__ = routes
      global.__engine1_routes__ = engine1_routes
      global.__engine2_routes__ = engine2_routes
      global.__engine3_routes__ = engine3_routes
    JAVASCRIPT

    assert_equal('/', context.eval('__routes__.root_path()'))
    assert_equal('/one/1/bar', context.eval('__engine1_routes__.bar_path({ engine1_id: "1" })'))
    assert_equal('/one/1/two/2', context.eval('__engine1_routes__.test_engine2_path({ engine1_id: "1", engine2_id: "2" })'))
    assert_equal('/one/1/two/2/', context.eval('__engine2_routes__.root_path({ engine1_id: "1", engine2_id: "2" })'))
    assert_equal('/one/1/two/2/foo', context.eval('__engine2_routes__.foo_path({ engine1_id: "1", engine2_id: "2" })'))
    assert_equal('/one/1/two/2/foo?foo=bar', context.eval('__engine2_routes__.foo_path({ engine1_id: "1", engine2_id: "2", foo: "bar" })'))
    assert_equal('http://example.com/one/1/two/2/foo?foo=bar', context.eval('__engine2_routes__.foo_url({ host: "http://example.com", engine1_id: "1", engine2_id: "2", foo: "bar" })'))
    assert_equal('/overwrite/foo', context.eval('__engine2_routes__.foo_path({ script_name: "/overwrite" })'))
    assert_equal('/three/bleh', context.eval('__engine3_routes__.bleh_path()'))
    assert_equal('/three/bleh?foo=bar', context.eval('__engine3_routes__.bleh_path({ foo: "bar" })'))
    Rails.application.reload_routes!
  end
end

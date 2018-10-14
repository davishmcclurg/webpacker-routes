require 'test_helper'
require 'execjs'

class Webpacker::Routes::Test < ActiveSupport::TestCase
  include ActionDispatch::Assertions::RoutingAssertions

  delegate :root_path, :source_entry_path, :routes_path, :public_path, :to => :'Webpacker.config'

  def compile(javascript, routes: Rails.application.routes, pack: 'test.js')
    [source_entry_path, routes_path].each do |dir|
      dir.rmtree if dir.exist?
      dir.mkdir
    end
    Webpacker::Routes.generate(routes)
    source_entry_path.join(pack).write(javascript)
    return false unless Dir.chdir(root_path) { Webpacker.compile }
    public_path.join(Webpacker.manifest.lookup('test.js').slice(1..-1)).read
  end

  test 'generates url/path helpers' do
    output = compile(<<-JAVASCRIPT)
      import * as routes from 'routes'
      global.__routes__ = routes
    JAVASCRIPT
    context = ExecJS.compile(output)
    assert_equal('/', context.eval('__routes__.root_path()'))
    assert_equal('http://example.com/', context.eval('__routes__.root_url({ host: "http://example.com" })'))
    assert_equal('/?foo=bar', context.eval('__routes__.root_path({ foo: "bar" })'))
  end

  test 'compilation fails for invalid route name' do
    refute compile(<<-JAVASCRIPT)
      import { invalid_url } from 'routes'
      invalid_url()
    JAVASCRIPT
  end

  test 'tree-shakes unused routes' do
    with_routing do |set|
      set.draw do
        get '/used/for/something', as: :used
        get '/tree/shook', as: :tree_shook
      end
      output = compile(<<-JAVASCRIPT, routes: set)
        import { used_path } from 'routes'
        used_path()
      JAVASCRIPT
      assert_match(/\/used\/for\/something/, output)
      assert_no_match(/\/tree\/shook/, output)
    end
  end
end

require 'abstract_unit'
require 'active_model'

class Bunny < Struct.new(:Bunny, :id)
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  def to_key() id ? [id] : nil end
end

class DeRjsBaseTest < Minitest::Test
  protected
  def generate_js(rjs)
    rewritten_source = DeRjs::Rewriter.rewrite_rjs(rjs)
    generator = DeRjs::JqueryGenerator.new(nil) { eval(rewritten_source)}
    generator.to_s
  end
end


class DeRjsTest < DeRjsBaseTest
  def setup
    super
    ActiveSupport.escape_html_entities_in_json  = true
  end

  def teardown
    ActiveSupport.escape_html_entities_in_json  = false
  end

  def _evaluate_assigns_and_ivars() end

  def test_insert_html_with_string
    assert_equal 'jQuery("#element").prepend("\\u003cp\\u003eThis is a test\\u003c/p\\u003e");',
      generate_js(%Q{ page.insert_html(:top, 'element', '<p>This is a test</p>') })
    assert_equal 'jQuery("#element").append("\\u003cp\u003eThis is a test\\u003c/p\u003e");',
      generate_js(%Q{ page.insert_html(:bottom, 'element', '<p>This is a test</p>') })
    assert_equal 'jQuery("#element").before("\\u003cp\u003eThis is a test\\u003c/p\u003e");',
      generate_js(%Q{ page.insert_html(:before, 'element', '<p>This is a test</p>') })
    assert_equal 'jQuery("#element").after("\\u003cp\u003eThis is a test\\u003c/p\u003e");',
      generate_js(%Q{ page.insert_html(:after, 'element', '<p>This is a test</p>') })
  end

  def test_replace_html_with_string
    assert_equal 'jQuery("#element").html("\\u003cp\\u003eThis is a test\\u003c/p\\u003e");',
      generate_js(%Q{ page.replace_html('element', '<p>This is a test</p>') })
  end

  def test_replace_element_with_string
    assert_equal 'jQuery("#element").replaceWith("\\u003cdiv id=\"element\"\\u003e\\u003cp\\u003eThis is a test\\u003c/p\\u003e\\u003c/div\\u003e");',
      generate_js(%Q{ page.replace('element', '<div id="element"><p>This is a test</p></div>') })
  end

  def test_insert_html_with_hash
    assert_equal 'jQuery("#element").prepend("<%= escape_javascript(render(:partial => "post", :locals => {:ab => "cd"})) %>");',
      generate_js(%Q{ page.insert_html(:top, 'element', :partial => "post", :locals => {:ab => "cd"}) })
  end

  def test_insert_html_with_var
    assert_equal 'jQuery("#element").prepend("<%= escape_javascript(@var) %>");',
      generate_js(%Q{ page.insert_html(:top, 'element', @var) })
  end

  def test_replace_html_with_hash
    assert_equal 'jQuery("#element").html("<%= escape_javascript(render(:partial => "post", :locals => {:ab => "cd"})) %>");',
      generate_js(%Q{ page.replace_html('element', :partial => "post", :locals => {:ab => "cd"}) })
  end

  def test_replace_html_with_var
    assert_equal 'jQuery("#element").html("<%= escape_javascript(@var) %>");',
      generate_js(%Q{ page.replace_html('element', @var) })
  end

  def test_replace_element_with_hash
    assert_equal 'jQuery("#element").replaceWith("<%= escape_javascript(render(:partial => "post", :locals => {:ab => "cd"})) %>");',
      generate_js(%Q{ page.replace('element', :partial => "post", :locals => {:ab => "cd"}) })
  end


  def test_remove
    assert_equal 'jQuery("#foo").remove();',
      generate_js(%Q{ page.remove('foo') })
    assert_equal 'jQuery("#foo,#bar,#baz").remove();',
      generate_js(%Q{ page.remove('foo', 'bar', 'baz') })
  end

  def test_show
    assert_equal 'jQuery("#foo").show();',
      generate_js(%Q{ page.show('foo') })
    assert_equal 'jQuery("#foo,#bar,#baz").show();',
      generate_js(%Q{ page.show('foo', 'bar', 'baz') })
  end

  def test_hide
    assert_equal 'jQuery("#foo").hide();',
      generate_js(%Q{ page.hide('foo') })
    assert_equal 'jQuery("#foo,#bar,#baz").hide();',
      generate_js(%Q{ page.hide('foo', 'bar', 'baz') })
  end

  def test_toggle
    assert_equal 'jQuery("#foo").toggle();',
      generate_js(%Q{ page.toggle('foo') })
    assert_equal 'jQuery("#foo,#bar,#baz").toggle();',
      generate_js(%Q{ page.toggle('foo', 'bar', 'baz') })
  end

  def test_alert
    assert_equal 'alert("hello");', generate_js(%Q{ page.alert('hello') })
  end

  def test_redirect_to
    assert_equal 'window.location.href = "http://www.example.com/welcome?a=b&c=d";',
      generate_js(%Q{ page.redirect_to("http://www.example.com/welcome?a=b&c=d") })
    assert_equal 'window.location.href = "<%= url_for(:action => \'welcome\') %>";',
      generate_js(%Q{ page.redirect_to(:action => 'welcome') })
  end

  def test_reload
    assert_equal 'window.location.reload();',
      generate_js(%Q{ page.reload })
  end

  def test_element_access
    assert_equal %(jQuery("#hello");), generate_js(%Q{ page['hello'] })
  end

  def test_element_access_on_variable
    assert_equal %(jQuery("#<%= dom_id(@var) %>");), generate_js(%Q{ page[@var] })
    assert_equal %(jQuery("#<%= dom_id(@var) %>").hide();), generate_js(%Q{ page[@var].hide })
  end

  def test_element_access_on_interpolated_string
    assert_equal %q(jQuery("#<%= "hello#{@var}" %>");), generate_js(%q{ page["hello#{@var}"] })
    assert_equal %q(jQuery("#<%= "hello#{@var}" %>").hide();), generate_js(%q{page["hello#{@var}"].hide })
  end

  def test_element_access_on_records
    assert_equal %(jQuery("#<%= dom_id(Bunny.new(:id => 5)) %>");), generate_js(%Q{ page[Bunny.new(:id => 5)] })
    assert_equal %(jQuery("#<%= dom_id(Bunny.new) %>");), generate_js(%Q{ page[Bunny.new] })
  end

  def test_element_access_on_dom_id
    assert_equal %(jQuery("#<%= dom_id(Bunny.new(:id => 5)) %>");), generate_js(%Q{ page[dom_id(Bunny.new(:id => 5))] })
    assert_equal %(jQuery("#<%= dom_id(Bunny.new) %>");), generate_js(%Q{ page[dom_id(Bunny.new)] })

    assert_equal %(jQuery("#<%= dom_id(dom_id(Bunny.new) + evil) %>");), generate_js(%Q{ page[dom_id(Bunny.new) + evil] })
  end

  def test_element_proxy_one_deep
    assert_equal %(jQuery("#hello").hide();), generate_js(%Q{ page['hello'].hide })
  end

  def test_element_proxy_variable_access
    assert_equal %(jQuery("#hello").style;), generate_js(%Q{ page['hello']['style'] })
  end

  def test_element_proxy_variable_access_with_assignment
    assert_equal %(jQuery("#hello").style.color = "red";), generate_js(%Q{ page['hello']['style']['color'] = 'red' })
  end

  def test_element_proxy_assignment
    assert_equal %(jQuery("#hello").width = 400;), generate_js(%Q{ page['hello'].width = 400 })
  end

  def test_element_proxy_two_deep
    skip "I don't think this has ever worked"
    assert_equal %(jQuery("#hello").hide("first").cleanWhitespace();), generate_js(%Q{ page.hide("first").clean_whitespace })
  end

  def test_select_access
    assert_equal %(jQuery("div.hello");), generate_js(%Q{ page.select('div.hello') })
  end

  def test_select_proxy_one_deep
    assert_equal %(jQuery("p.welcome b").first().hide();), generate_js(%Q{ page.select('p.welcome b').first.hide })
  end

  def test_visual_effect
    assert_equal %(jQuery(\"#blah\").effect(\"puff\",{});),
      generate_js(%Q{ page.visual_effect(:puff,'blah') })

    assert_equal %(jQuery(\"#blah\").effect(\"puff\",{});),
      generate_js(%Q{ page['blah'].visual_effect(:puff) })
  end

  def test_visual_effect_toggle
    assert_equal %(jQuery(\"#blah\").toggle(\"fade\",{});),
      generate_js(%Q{ page.visual_effect(:toggle_appear,'blah') })
  end

  def test_visual_effect_with_variable
    assert_equal %(jQuery(\"#<%= "blah" + blah.id %>\").toggle(\"fade\",{});),
      generate_js(%Q{ page.visual_effect(:toggle_appear,"blah" + blah.id) })
  end

  def test_collection_first_and_last
    js = generate_js(%Q{
    page.select('p.welcome b').first.hide()
    page.select('p.welcome b').last.show()
    })
    assert_equal <<-EOS.strip, js
jQuery("p.welcome b").first().hide();
jQuery("p.welcome b").last().show();
      EOS
  end

  def test_collection_proxy_with_pluck
    js = generate_js(%Q{ page.select('p').pluck('a', 'className') })
    assert_equal %(var a = jQuery("p").pluck("className");), js
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class MetroTest < Test::Unit::TestCase
  fixtures :metros

  def test_should_create_record
    metro = create
    assert metro.valid?, "Metro was invalid:\n#{metro.errors.to_yaml}"
  end
  
private
  
  def create(options={})
    Metro.create({
      :name => "Hamburg",
      :state => "Hamburg",
      :country => "Germany"
    }.merge(options))
  end
end

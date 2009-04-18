require 'test/unit'

require 'rubygems'
require 'active_support'
require 'mongo_record'

require File.dirname(__FILE__) + '/../lib/mongo_tree'

MongoRecord::Base.connection = XGen::Mongo::Driver::Mongo.new.db("mongo_tree_test")

class Taxon < MongoRecord::Base
  mongo_tree
end

class TreeTest < Test::Unit::TestCase
  
  def setup
    @root = Taxon.new({:name=>"ROOT", :content=>"ROOT content"})
    @root.save
    @child1 = Taxon.new({:name=>"Child", :content=>"Child content"})
    @root << @child1
    @child2 = Taxon.new({:name=>"Child2", :content=>"Child 2 content"})
    @root << @child2
    @root.save
    @grandchild = Taxon.new({:name=>"GrandChild", :content=>"Grand content"})
    @child1 << @grandchild
    @child1.save
    @greatgrandchild = Taxon.new({:name=>"GreatGrandChild", :content=>"Great grand content"})
    @grandchild << @greatgrandchild    
    @grandchild.save
  end
  
  def test_children
    assert_equal @root.children, [@child1, @child2]
    assert_equal @child1.children, [@grandchild]
  end
  
  def test_parents
    assert_equal @greatgrandchild.parent.id, @grandchild.id
    assert_equal @greatgrandchild.ancestors.map{|a| a.id}, [@root.id, @child1.id, @grandchild.id]
    assert_equal @greatgrandchild.root, @root
  end
  
  def test_siblings    
    assert_equal @child1.siblings.first.id, @child2.id
  end
    
  def test_adding_children
    child_count = @root.children.size
    @newchild = Taxon.new({:name=>"NewChild", :content=>"New child content"})
    @newchild.save
    @root << @newchild
    assert_equal @root.children.size, child_count + 1
  end
  
  def test_deletions
    @greatgrandchild = @grandchild.remove!(@greatgrandchild)
    assert_equal @greatgrandchild.parents, []
    assert_equal @grandchild.children, []
  end
  
end
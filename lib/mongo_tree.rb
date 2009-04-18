module MongoTree
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def mongo_tree(options={})
      fields :name
      fields :content
      fields :parents

      fields :created_at
      fields :updated_at
      
      @@fieldSep = '|'
      @@recordSep = "\n"
      
      class_eval <<-EOV
        include MongoTree::InstanceMethods
      EOV
    end
    
  end
  
  module InstanceMethods
    
    def initialize(options={})   
      super   
      self.set_as_root!
      
      if self.parents.nil?
        self.parents = []
      end
    end
    
    def to_s
      s = size()
      "Node ID: #{@name} Content: #{@content} Parent: " +
              (is_root?()  ? "ROOT" : "#{@parent.name}") +
              " Children: #{children.length}" +
              " Total Nodes: #{s}"
    end
      
    # Convenience synonym for Tree#add method. 
    # This method allows a convenient method to add
    # children hierarchies in the tree.
    # E.g. root << child << grand_child
    def <<(child)
        add(child)
    end

    # Adds the specified child node to the receiver node.
    # The child node's parent is set to be the receiver.
    # The child is added as the last child in the current
    # list of children for the receiver node.
    def add(child)
        raise "Child already added" if child.parents.include?(self.id)
        child.parents = []
        child.parents << self.parents 
        child.parents << self.id
        child.parents.flatten!
        child.save
        return child

    end

    # Removes the specified child node from the receiver node.
    # The removed children nodes are orphaned but available
    # if an alternate reference exists.
    # Returns the child node.
    def remove!(child)
      # Make sure child belongs to the object trying to remove it
      child = self.children.select {|c| c.id == child.id}.first
      unless child.nil?
        old_parents = child.parents
        child.parents = []
        child.save
        # Update the parent tree of all this object's children
        child.descendants.each do |descendant, level|
          descendant.parents = descendant.parents - old_parents
          descendant.save
        end
      end
      
      return child
    end

    # Removes this node from its parent. If this is the root node,
    # then does nothing.
    def remove_from_parent!
        parent.remove!(self) unless is_root?
    end
    
    # Removes all children from the receiver node.
    def remove_all!
        for child in children
            child.remove_from_parent!
        end
        self
    end

    # Indicates whether this node has any associated content.
    def has_content?
        @content != nil
    end

    # Indicates whether this node is a root node. Note that
    # orphaned children will also be reported as root nodes.
    def is_root?
        parents == []
    end

    # Indicates whether this node has any immediate child nodes.
    def has_children?
        children.length != 0
    end

    # Returns a multi-dimensional arraoy of children objects and the level
    # where level is the depth in the hierarchy.
    def descendants(max_level=nil)
      children=[]
      self.class.find(:all).each do |obj|
        if obj.parents.include?(self.id)
          level = obj.parents.reverse.index(self.id)            
          if max_level.nil?
            children << [obj, level]
          else
            children << [obj, level] if level <= max_level
          end
        end
      end
      return children
    end
    
    # Returns all children of an object
    def children
      descendants(0).map {|c| c[0]}
    end
          
    # Returns the root for this node.
    def root
      self.parents.blank? ? self : self.class.find(self.parents.first)
    end
    
    def parent
      self.class.find(self.parents.last) rescue nil
    end      
    
    def ancestors
      self.class.find(self.parents)
    end

    # Returns every node (including the receiver node) from the
    # tree to the specified block.
    def each &block
        yield self
        children { |child| child.each(&block) }
    end

    # Returns the requested node from the set of immediate
    # children.
    # 
    # If the key is _numeric_, then the in-sequence array of
    # children is accessed (see Tree#children).
    # If the key is not _numeric_, then it is assumed to be
    # the *name* of the child node to be returned.
    def [](key)
        raise "Key needs to be provided" if key == nil
        
        if key.kind_of?(Integer)
          children[key]
        else
          descendants.select {|child, level| child.name == key}.first[0]
        end
    end

    # Returns the total number of nodes in this tree, rooted
    # at the receiver node.
    def size
        descendants.size
    end

    # Convenience synonym for Tree#size
    def length
        size()
    end

    # Pretty prints the tree starting with the receiver node.
    def print_tree(tab = 0)
        puts((' ' * tab) + self.to_s)
        children {|child| child.print_tree(tab + 4)}
    end

    # Returns an array of siblings for this node.
    # If a block is provided, yeilds each of the sibling
    # nodes to the block.
    def siblings
        if block_given?
            return nil if is_root?
            for sibling in parent.children
              yield sibling if sibling != self
            end
        else
            siblings = []
            parent.children.each {|sibling| siblings << sibling if sibling != self}
            siblings
        end
    end

    # Provides a comparision operation for the nodes. Comparision
    # is based on the natural character-set ordering for the
    # node names.
    def <=>(other)
        return +1 if other == nil
        self.name <=> other.name
    end

    # Freezes all nodes in the tree
    def freeze_tree!
        each {|node| node.freeze}
    end
    
    # Creates a dump representation
    def create_dump_rep
        strRep = String.new
        strRep << @name << @@fieldSep << (is_root? ? @name : parent.name)
        strRep << @@fieldSep << Marshal.dump(@content) << @@recordSep
    end
    
    def _dump(depth)
        strRep = String.new
        each {|node| strRep << node.createDumpRep}
        strRep
    end    
     

    # Private method which sets this node as a root node.
    def set_as_root!
        parents = []
    end
  end 
end

class MongoRecord::Base
  include MongoTree
end
# encoding: utf-8
module Mongoid #:nodoc:
  module Persistence #:nodoc:
    # Insert is a persistence command responsible for taking a document that
    # has not been saved to the database and saving it. This specific class
    # handles the case when the document is embedded in another.
    #
    # The underlying query resembles the following MongoDB query:
    #
    #   collection.insert(
    #     { "_id" : 1, "field" : "value" },
    #     false
    #   );
    class InsertEmbedded < Command
      # Insert the new document in the database. If the document's parent is a
      # new record, we will call save on the parent, otherwise we will $push
      # the document onto the parent.
      #
      # Example:
      #
      # <tt>Insert.persist</tt>
      #
      # Returns:
      #
      # The +Document+, whether the insert succeeded or not.
      def persist
        parent = @document._parent
        if parent.new_record?
          parent.insert
        else
          update = { @document._inserter => { @document._position => @document.raw_attributes } }
          @collection.update(parent._selector, update, @options.merge(:multi => false))
        end
        @document.new_record = false; @document
      end
    end
  end
end

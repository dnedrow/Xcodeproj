module Xcodeproj
  class Project

    # This class represents an ordered relationship to many objects.
    #
    # It works in conjunction with the {AbstractObject} class to ensure that
    # the project is not serialized with unreachable objects by updating the
    # with reference count on modifications.
    #
    # @note Concerning the mutations methods it is safe to call only those
    #       which are overridden to inform objects reference count. Ideally all
    #       the array methods should be covered, but this is not done yet.
    #       Moreover it is a moving target because the methods of array
    #       usually are implemented in C
    #
    # @todo Cover all the mutations methods of the {Array} class.
    #
    class ObjectList < Array

      # {Xcodeproj} clients are not expected to create instances of
      # {ObjectList}, it is always initialized empty and automatically by the
      # synthesized methods generated by {AbstractObject.has_many}.
      #
      def initialize(attribute, owner)
        @attribute = attribute
        @owner = owner
      end

      # @return [Array<Class>] The attribute that generated the list.
      #
      attr_reader :attribute

      # @return [Array<Class>] The object that owns the list.
      #
      attr_reader :owner

      #------------------------------------------------------------------------#

      # @!group Integration with {ObjectList}

      # @return [Array<String>] The UUIDs of all the objects referenced by this
      #   list.
      #
      def uuids
        map { |obj| obj.uuid }
      end

      #------------------------------------------------------------------------#

      # @!group Notification enabled methods

      # TODO: the overridden methods are incomplete.

      # Adds an array of objects to list and updates their references count.
      #
      # @param [Array<AbstractObject, ObjectDictionary>] object
      #   an array of objects to add to the list.
      #
      # @return [void]
      #
      def +(objects)
        super
        perform_additions_operations(objects)
      end

      # Adds an object to list and updates its references count.
      #
      # @param [AbstractObject, ObjectDictionary] object
      #   the object to add to the list.
      #
      # @return [void]
      #
      def <<(object)
        super
        perform_additions_operations(object)
      end

      # Removes an object to list and updates its references count.
      #
      # @param [AbstractObject, ObjectDictionary] object
      #   the object to delete from the list.
      #
      # @return [void]
      #
      def delete(object)
        super
        perform_deletion_operations(object)
      end

      #------------------------------------------------------------------------#

      # @!group Notification Methods

      private

      # Informs an object that it was added to the list. In practice it adds
      # the owner of the list as referrer to the objects. It also validates the
      # value.
      #
      # @return [void]
      #
      def perform_additions_operations(objects)
        objects = [objects] unless objects.is_a?(Array)
        objects.each do |obj|
          obj.add_referrer(owner)
          attribute.validate_value(obj) unless obj.is_a?(ObjectDictionary)
        end
      end

      # Informs an object that it was removed from to the list, so it can
      # remove it from its referrers and take the appropriate actions.
      #
      # @return [void]
      #
      def perform_deletion_operations(objects)
        objects = [objects] unless objects.is_a?(Array)
        objects.each do |obj|
          obj.remove_referrer(owner) unless obj.is_a?(ObjectDictionary)
        end
      end
    end
  end
end

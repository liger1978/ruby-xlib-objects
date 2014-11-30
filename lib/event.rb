module CappX11
  class Event
    attr_reader :struct, :name

    def initialize(union)
      event = union[:type]
      union_member = X11::EVENT_TO_UNION_MEMBER[event]
      @name = X11::EVENT.key(event)
      @struct = union[union_member]

      @struct.members.each do |key|
        define_singleton_method(key) do
          @struct[key]
        end
      end
    end

    def method_missing(method_name)
      nil
    end
  end
end
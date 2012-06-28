module Platform
  module Api
    class AlreadyJsonedString < String
      def to_json(options={})
        self
      end
    end # class AlreadyJsonedString
  end # module Api
end # module Platform

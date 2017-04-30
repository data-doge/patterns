module NameFinderHelper
  def find_my_name(obj)
    return obj.name if obj.respond_to?(:name)
    return obj.full_name if obj.respond_to?(:full_name)
    return obj.title if obj.respond_to?(:title)
    return obj.class.to_s # last case
  end
end

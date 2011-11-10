[User, Bookmark, Platform::Application, Platform::Developer].each do |klass|
  klass.has_platform_api_proxy
end
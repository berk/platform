module Platform::SimpleStringPermissions

  def set_permission(key, value)
    self.permissions = if value
      (permissions.to_s.split(',').to_set + key.to_s)
    else
      (permissions.to_s.split(',').to_set - key.to_s)
    end.join(',')
  end

  def has_permission?(key)
    permissions.to_s.split(',').include?(key.to_s)
  end

end

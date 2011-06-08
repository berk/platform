class Platform::Media::Media < ActiveRecord::Base
  set_table_name :platform_media

  def local_dir
    @local_dir ||= [Platform::Config.media_path, file_location].join("/")
  end

  def local_path
    @local_path ||= [local_dir, file_name].join("/")
  end
  
  def url
    [Platform::Config.media_directory, file_location, file_name].join("/")
  end
  
  def write(file, opts = {})
    self.content_type = 'image/png' 
    self.file_location = self.class.generate_local_dir
    self.file_name = "#{Platform::RandomPasswordGenerator.random_password}.png" 
    
    FileUtils.mkdir_p(local_dir) unless File.exist?(local_dir)

    image = Magick::ImageList.new(file.path)
    image = image.resize(opts[:size], opts[:size]) if opts[:size]
    image.write(local_path)
    FileUtils.chmod(0644, local_path)

    save
  end
  
  def self.generate_local_dir
    rand(2 ** 32).to_s(16).rjust(8, "0").scan(/.{2}/).join("/")
  end
  
end

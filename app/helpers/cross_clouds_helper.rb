module CrossCloudsHelper
  def cross_cloud
    cc_list = Array.new
    cc_config.each do |cc, cloud|
      cc_list.push cloud["name"]
    end
    cc_list
  end

  def cross_cloud_image
    cc_list = Array.new
    cc_config.each do |cc, cloud|
      cc_list.push cloud["image"]
    end
    #[ "Amazon EC2", "hp cloud", "Google cloud Engine"]
    cc_list
  end

  def cc_config
    YAML.load(File.open("#{Rails.root}/config/cross_clouds.yml", 'r'))
  end

  def cc_type(name)
    @type = ""
    cc_config.each do |cc, cloud|
      if cloud["name"] == name
        @type = cloud["type"]
      end
    end
    @type
  end

  def cross_cloud_bucket
    Rails.configuration.storage_crosscloud
  end

  def ssh_files_bucket
    puts "--> ssh_files_bucket #{Rails.configuration.storage_sshfiles}"
    Rails.configuration.storage_sshfiles
  end

  def cloud_tool_setting_bucket
    Rails.configuration.storage_cloudtool
  end

  if Rails.configuration.storage_type == 's3'
    def vault_s3_url
      Rails.configuration.storage_server_url+"/"+cross_cloud_bucket
    end

    def cloudtool_base_url
      Rails.configuration.storage_server_url+"/"+cloud_tool_setting_bucket
    end
  end

  def get_provider_value(prov)
    @value = ""
    cc_config.each do |cc, cloud|
      if cloud["name"] == prov
        @value = cloud["value"]
      end
    end
    @value
  end

  def list_aws_data(access_key, secret_key, region)
    connection = Fog::Compute.new(
    :provider => 'AWS',
    :aws_access_key_id => "#{access_key}",
    :aws_secret_access_key => "#{secret_key}",
    :region => "#{region}" )
    #List Images
    @aws_imgs=[]
    img = connection.images.all({"owner-id" => "915134024303"})
    img.each do |i|
      @aws_imgs.push({"id" => "#{i.id}", "name" => "#{i.name}"})
    #@aws_imgs.push("Name:#{i.name}, Id:#{i.id}")
    end

    #List Flavors
    @aws_flavors=[]
    connection.flavors.each do |f|
      @aws_flavors.push({"id" => "#{f.id}", "ram" => "#{f.ram}", "core" => "#{f.cores}", "disk" => "#{f.disk}"})
    #@aws_flavors.push("Ram:#{f.ram}, Core:#{f.cores}, Disk:#{f.disk}, Id:#{f.id}")
    end

    #List Keypairs
    @aws_keypairs=[]
    connection.key_pairs.each do |k|
      @aws_keypairs.push("#{k.name}")
    end

    #List Securitygroups
    @aws_groups=[]
    connection.security_groups.each do |s|
      @aws_groups.push("#{s.name}")
    end

    return @aws_imgs, @aws_flavors, @aws_keypairs, @aws_groups

  end

end

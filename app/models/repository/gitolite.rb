
class Repository::Gitolite < Repository::Git

  def self.adapter_class
    Gitolito::GitoliteAdapter
  end

  def self.scm_name
    "Gitolite"
  end

end

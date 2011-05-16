require 'redmine'
require_dependency 'principal'
require_dependency 'user'

require_dependency 'redmine_gitolite'
require_dependency 'redmine_gitolite/gitolite_adapter'
require_dependency 'redmine_gitolite/patches/repositories_helper_patch'

Redmine::Plugin.register :redmine_gitolite do
  name 'Redmine Gitolite plugin'
  author 'Christian Käser, Zsolt Parragi, Yunsang Choi, Joshua Hogendorn, Jan Schulz-Hofen and others'
  description 'Enables Redmine to update a gitolite server.'
  version '0.1.0'
  settings :default => {
    'gitoliteUrl' => 'git@localhost:gitolite-admin.git',
    'gitoliteIdentityFile' => '/path/to/admin/id_rsa',
    'developerBaseUrls' => 'git@example.com:,https://[user]@www.example.com/git/',
    'readOnlyBaseUrls' => 'http://www.example.com/git/',
    'basePath' => '/var/lib/gitolite/repositories/',
    }, 
    :partial => 'redmine_gitolite'
end

# initialize hook
class GitolitePublicKeyHook < Redmine::Hook::ViewListener
  render_on :view_my_account_contextual, :inline => "| <%= link_to(l(:label_public_keys), public_keys_path) %>" 
end

class GitoliteProjectShowHook < Redmine::Hook::ViewListener
  render_on :view_projects_show_left, :partial => 'redmine_gitolite'
end

# TODO: this part still doesn't work in dev mode... even dies with Dispatcher. WHY???
# initialize association from user -> public keys
require 'user'
User.send(:has_many, :gitolite_public_keys, :dependent => :destroy)
Redmine::Scm::Base.add "Gitolite" unless Redmine::Scm::Base.all.include? "Gitolite"

# initialize observer
ActiveRecord::Base.observers = ActiveRecord::Base.observers << RedmineGitoliteObserver


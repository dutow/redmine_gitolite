require_dependency 'repositories_helper'
module RedmineGitolite
  module Patches
    module RepositoriesHelperPatch

      def gitolite_field_tags(form, repository)
        val = ""
        proj = @project
        projs = []
        projs << "#{proj.identifier}.git"
        while proj.parent
          proj = proj.parent
          projs << proj.identifier
        end
        val = File.join(projs.reverse)

        content_tag('p', form.text_field(
                          :url, :label => l(:field_path_to_repository),
                          :size => 60, :required => true,
                          :disabled => (repository && !repository.root_url.blank?),
                          :value => val
                            ) +
                          '<br />' + l(:text_gitolite_repository_note)) +
        content_tag('p', form.check_box(
                            :extra_report_last_commit,
                            :label => l(:label_git_report_last_commit)
                            ))
      end

    end
  end
end

RepositoriesHelper.send(:include, RedmineGitolite::Patches::RepositoriesHelperPatch) unless RepositoriesHelper.include?(RedmineGitolite::Patches::RepositoriesHelperPatch)


module Fastlane
  module Actions
    class GitCommitAllAction < Action
      def self.run(params)
          Action.sh "git add -A"
          Actions.sh "git commit -am \"#{params[:message]}\""
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Commit all unsaved changes to git."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_GIT_COMMIT_ALL",
                                       description: "The git message for the commit",
                                       is_string: true)
        ]
      end

      def self.authors
        ["ZeroOnet"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end

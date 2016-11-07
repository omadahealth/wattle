class TrackersController < ApplicationController
  before_filter :load_grouping

  PROJECTS_THAT_INCLUDE_LANGUAGE_LABEL = ['Red', 'Blue', 'Omada Chores']

  def create
    story_name = @grouping.tracker_story_name
    description = "[View grouping #{@grouping.id} in Wattle](#{grouping_url(@grouping)})"
    story = current_user.tracker.create_story(story_params[:tracker_project],
      name: story_name,
      description: description,
      labels: [language]
    )

    @grouping.update!(pivotal_tracker_story_id: story.id)
    redirect_to :back
  end

  protected

  def story_params
    params.require(:tracker).permit(:tracker_project)
  end

  def load_grouping
    @grouping = Grouping.find(params.require(:tracker).permit(:grouping_id)[:grouping_id])
  end

  def language
    if story_params[:tracker_project].in? PROJECTS_THAT_INCLUDE_LANGUAGE_LABEL
      @grouping.language
    end
  end
end

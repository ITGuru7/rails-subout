class Api::V1::CommentsController < Api::V1::BaseController
  def create
    opportunity = Opportunity.find(params[:opportunity_id])
    comment = opportunity.comments.create(:body => params[:comment][:body], :commenter => current_company)
    respond_with_namespace(opportunity, comment)
  end
end

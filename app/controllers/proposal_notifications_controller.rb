class ProposalNotificationsController < ApplicationController
  skip_authorization_check

  def new
    @notification = ProposalNotification.new
    @proposal = Proposal.find(params[:proposal_id])
  end

  def create
    @notification = ProposalNotification.new(notification_params)
    @proposal = Proposal.find(notification_params[:proposal_id])
    if @notification.save
      @proposal.voters.each do |voter|
        Notification.add(voter.id, @notification)
        if voter.email_on_proposal_notification?
          Mailer.proposal_notification(@notification, voter).deliver_later
        end
      end
      redirect_to @notification, notice: I18n.t("flash.actions.create.proposal_notification")
    else
      render :new
    end
  end

  def show
    @notification = ProposalNotification.find(params[:id])
  end

  private

  def notification_params
    params.require(:proposal_notification).permit(:title, :body, :proposal_id)
  end

end
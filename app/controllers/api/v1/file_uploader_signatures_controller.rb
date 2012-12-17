class Api::V1::FileUploaderSignaturesController < Api::V1::BaseController
  skip_before_filter :restrict_access

  def new
    render json: FileUploaderSignature.new.generate
  end
end

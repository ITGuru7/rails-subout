class Api::V1::FileUploaderSignaturesController < Api::V1::BaseController
  def new
    render json: FileUploaderSignature.new.generate
  end
end

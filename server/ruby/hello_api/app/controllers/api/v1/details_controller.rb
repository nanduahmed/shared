
class Api::Details < ApplicationController
  respond_to :json
  def show
    puts("ahmed")
    render json: {smart:"success"}, status :200
  end
end

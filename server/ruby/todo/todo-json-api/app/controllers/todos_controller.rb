class TodosController < JSONAPI::ResourceController

  def show
    time = Time.new
    puts("\n*************************************************************\n")
    puts "==>> " + time.inspect + " <<==\n" ##+ "===" time.hour + ":" time.min + ":" + time.sec + "<<==\n"\
    puts params["region"]
    # puts params

    puts("***************************************************************\n")

    render json:  '{val:"hh", an:""}', status: :'200'
  end

end

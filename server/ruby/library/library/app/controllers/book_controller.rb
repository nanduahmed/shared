class BookController < ApplicationController

  def list
    @books = Book.all
  end

def show
  puts "nandu Ahmed"
  @book = Book.find(params[:id])

end

def ajson
  # var bparams = {title:"T", price:1,description:"DD", subject_id:3}
  bparams =  { "title": "An Old Book", "description": "123vdvv " , "subject_id":4, "price":210}
  @book = Book.new(bparams)
  puts @book.title
  if @book.save
    # redirect_to :action => 'list'
  else
    @subjects = Subject.all
    render :action => 'list'
  end
end
#
def axml
  # render :xml => <xml></xml>
  render :action => 'list'
end

def new
  @book = Book.new
  @subjects = Subject.all
end

def create
  puts "=====================params==============================================="
  puts params
  puts "===================================================================="

  @book = Book.new(book_params)
  puts "===============Book====================================================="
  puts @book
  puts "===================================================================="
  if @book.save
    redirect_to :action => 'list'
  else
    @subjects = Subject.all
    render :action => 'new'
  end
end

def edit
  @book = Book.find(params[:id])
  @subjects = Subject.all
end

def update
  @book = Book.find(params[:id])

  if @book.update_attributes(book_param)
    redirect_to :action => 'show', :id => @book
  else
    @subjects = Subject.all
    render :action => 'edit'
  end
end

def delete
  Book.find(params[:id]).destroy
  redirect_to :action => 'list'
end

def show_subjects
  @subject = Subject.find(params[:id])
end

def book_params
  params.require(:books).permit(:title, :price, :subject_id, :description)
  # params.require(:books).permit(:title)

end

end

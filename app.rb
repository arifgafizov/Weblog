require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'weblog.db'
	# возвращает результат как хеш а не массив
	@db.results_as_hash = true 
end

# before вызывается каждый раз при перезагрузке
# любой страницы

before do
	# индициализация БД
	init_db
end

configure do
	init_db
	# создает таблицу если таблица не существует
	@db.execute 'create table if not exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		username TEXT
	)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
  erb :new
end

post '/new' do
	content = params[:content]
	username = params[:username]
  
  	# сохранение данных в БД

	@db.execute 'insert into Posts (content, created_date, username) values (?, datetime(), ?)', [content, username]
	
	#erb "#{username}"
  	erb "#{content} - #{username}"
end
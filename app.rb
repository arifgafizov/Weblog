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
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

get '/new' do
  erb :new
end

post '/new' do
	@content = params[:content]
	@username = params[:username]

	#if content.length < 1
	#	@error = 'Type post text'
	#	return erb :new
	#elsif username.length < 1
	#	@error = 'Type your name'
	#	return erb :new
	#end

	# сохранение ввода при не полном заполнении данных
	hh = {
		:content => 'Type post text',
		:username => 'Type your name'
		}


	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ""
		return erb :new
	end

  
  	# сохранение данных в БД

	@db.execute 'insert into Posts (content, created_date, username) values (?, datetime(), ?)', [@content, @username]
	
	# перенаправление на главную страницу

	redirect to '/'
end

get '/details/:post_id' do
  	# получаем переменную из url'a
	post_id = params[:post_id]

	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	# выбираем этот один пост в переменную @row
	@post_detail = results[0]

	erb :details
end
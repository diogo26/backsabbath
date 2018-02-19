puts "\033[0;34mDigite o nome do projeto. Ex: projectName-backend\033[0m \n"
project_name = gets.chomp

puts "\033[0;34mDigite a url do repositorio do novo projeto\033[0m \n"
repository_url = gets.chomp

bd = ''
loop do
	puts "\033[0;34mEscolha o banco de dados\033[0m \n"
	puts "\033[0;34m[1] MYSQL\033[0m \n"
	puts "\033[0;34m[2] POSTGRE\033[0m \n"
	puts "\033[0;34m[3] SQLITE\033[0m \n"
	bd = gets.chomp
	break if bd.to_i >= 1 && bd.to_i <= 3
end

puts "\033[0;34mO projeto tera admin ? [y/n]\033[0m \n"
admin = gets.chomp

puts "\033[0;34mCriando projeto .......\033[0m \n"

begin
    #clonig base project and creating the new one
    system "cd .. && git clone git@bitbucket.org:ioasys/backsabbath-backend.git && mv backsabbath-backend #{project_name}"
    
    #config the database file
    case bd.to_i
        when 1
            system "cp #{Dir.pwd}/mysql/database.example.yml #{Dir.pwd}/../#{project_name}/config"
            system "cp #{Dir.pwd}/mysql/database.yml #{Dir.pwd}/../#{project_name}/config"
        when 2
            system "cp #{Dir.pwd}/postgre/database.example.yml #{Dir.pwd}/../#{project_name}/config"
            system "cp #{Dir.pwd}/postgre/database.yml #{Dir.pwd}/../#{project_name}/config"
        when 3
            system "cp #{Dir.pwd}/sql/database.example.yml #{Dir.pwd}/../#{project_name}/config"
            system "cp #{Dir.pwd}/sql/database.yml #{Dir.pwd}/../#{project_name}/config"
    end

    #create files for admin
    if admin.downcase == "y"
        system "cp #{Dir.pwd}/admin/Gemfile #{Dir.pwd}/../#{project_name}"
        system "cp #{Dir.pwd}/admin/admin_controller.rb #{Dir.pwd}/../#{project_name}/app/controllers"
    end

    #change to the new project directory and setting new origin
    Dir.chdir "#{Dir.pwd}/../#{project_name}"
    system "rm -Rf .git/ && git init && git remote add origin #{repository_url}"

    #setting devise
    system "bundle install"
    system "rails g pundit:install && rails g devise:install"
    system "rails g devise User"

    #uncomment config.secret_key
    text = File.read("#{Dir.pwd}/config/initializers/devise.rb")
    new_contents = text.gsub("# config.secret_key = ", "config.secret_key = ")

    #write changes to the file
    File.open("#{Dir.pwd}/config/initializers/devise.rb", "w") {|file| file.puts new_contents }

    #create the authentication
    system "cd lib && wget https://github.com/arturhaddad/simple_token_auth/archive/master.zip && unzip master.zip 'simple_token_auth-master/generators/*' && rsync -av simple_token_auth-master/generators ./ && rm -rf master.zip && rm -rf simple_token_auth-master"
	system "rails g authentication User"
		
	#add passwords controller
	system "cp #{Dir.pwd}/../backsabbath/auth/passwords_controller.rb #{Dir.pwd}/app/controllers/api/v1/auth"

	#add passwords routes
	text = File.read("#{Dir.pwd}/config/routes.rb")
    new_contents = text.gsub("delete 'sign_out' => 'sessions#destroy'", "delete 'sign_out' => 'sessions#destroy'\npost 'passwords' => 'passwords#create'\npatch 'passwords' => 'passwords#update'\nput 'passwords' => 'passwords#update'")

    File.open("#{Dir.pwd}/config/routes.rb", "w") {|file| file.puts new_contents }


    puts "\033[0;34mProjeto criado, coloque sua senha do bd no database e rode o create migrate seed.\033[0m \n"
rescue Exception => e  
    puts e.message  
    puts e.backtrace.inspect  
end
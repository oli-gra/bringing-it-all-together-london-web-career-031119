class Dog
  attr_accessor :name, :breed
	attr_reader :id

	def initialize(id: nil, name:, breed:)
	   @name = name
	   @breed = breed
	   @id = id
	end

	def self.create_table
	  DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
	end

	def self.drop_table
	  DB[:conn].execute('DROP TABLE IF EXISTS dogs')
	end

	def update
	  DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', @name, @breed, @id)
	end.first

	  def save
	    if @id
	      @update
	    else
	      DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?, ?)', @name, @breed)
	      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	    end
	    self
	  end

	  def self.create(name:, breed:)
	    dog = Dog.new(name: name, breed: breed)
	    return dog.save
	  end

	  def self.new_from_db(row)
	    id = row[0]
	    name = row[1]
	    breed = row[2]
	    Dog.new(id: id, name: name, breed: breed)
	  end

	  def self.find_by_name(name)
	    DB[:conn].execute('SELECT * FROM dogs WHERE name = ? LIMIT 1', name).map do |row|
	      self.new_from_db(row)
	    end
	  end

	  def self.find_by_id(id)
	    DB[:conn].execute('SELECT * FROM dogs WHERE id = ? LIMIT 1', id).map do |row|
	      Dog.new_from_db(row)
	    end.first
	  end

	  def self.find_or_create_by(name:, breed:)
	    if DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1', name, breed).empty?
	      dog = Dog.create(name: name, breed: breed)
	    else
	      dog = Dog.new(id: doggo[0][0], name: dog[0][1], breed: dog[0][2])
	    end
      dog
	  end

	end

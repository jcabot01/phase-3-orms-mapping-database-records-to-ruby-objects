require 'pry'

class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    #self.new is equivalent to Song.new
    self.new(id: row[0], name: row[1], album: row[2])  
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    DB[:conn].execute(sql).map do |row| #>>passing in the "sql" from above to our DB hash located in the environment file
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name) #pass in a name we want to search to find database raw data, and thus return as an array by turning it back into a Ruby object
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row| #the return value will be an array (cause ya know, map!)
      self.new_from_db(row)
    end.first #this grabs the "first" element in the array returned by the map.  Known as a "chain" to do that.
  end

end

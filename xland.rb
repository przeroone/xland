require 'forgery'

class Human
  attr_accessor :name, :gender, :married, :couple, :age
  MIN_MARRIAGE_AGE = 18
  GENDER_RATE = 0.5

  @@citizen = []
  @@died_citizen = []

  def self.citizen; @@citizen; end

  def self.died_citizen; @@died_citizen; end

  def initialize(gender = nil, age = nil)
    @gender = (gender || (rand > GENDER_RATE ? 'M' : 'F'))
    @name = Forgery::Name.full_name
    @married = false
    @age = (age || 0.0)
  end

  def marry
    if @age > MIN_MARRIAGE_AGE
      @couple = @@citizen.select{ |c| c.age > MIN_MARRIAGE_AGE and !c.married and c.gender != (@gender == 'M' ? 'F' : 'M') }.sample
      if @couple
        @married = true
        @couple.married = true
      end
    end
  end
end

class Xland
  CYCLE_TIME = 0.5
  MARRIAGE_RATE = 0.3
  BIRTH_RATE = 0.3

  def initialize
    10.times do
      Human.citizen.push Human.new('M', 18)
      Human.citizen.push Human.new('F', 18)
    end
  end

  def run
    begin
      unless Human.citizen.empty?
        marriage
        birth
        death
        age
      end
      print
      sleep CYCLE_TIME
    end while true
  end

  def sample
    rand(Human.citizen.size)
  end

  def marriage
    Human.citizen[sample].marry if rand < MARRIAGE_RATE
  end

  def birth
    Human.citizen.push Human.new if rand < BIRTH_RATE and Human.citizen[sample].married
  end

  def death
    s = sample
    h = Human.citizen[s]
    r = case h.age
        when 0..60 then 0.1
        when 61..80 then 0.6
        else 0.8
        end
    if rand < r
      Human.died_citizen.push h
      Human.citizen.delete_at(s)
    end
  end

  def age
    Human.citizen.each do |h|
      h.age += 0.2
    end
  end

  def print
    puts "\e[H\e[2J"
    puts "Total: #{Human.citizen.size}"
    info = Human.citizen.map do |c|
      "#{c.name}/#{c.gender}/#{c.married ? 'M' : 'S'}/#{"%.2f" % c.age}"
    end
    puts (info || []).join(', ')
  end
end

Xland.new.run

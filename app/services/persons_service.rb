# frozen_string_literal: true

class PersonsService

  attr_reader :persons

  def initialize(persons, relations)
    @persons = persons
    @relations = relations
  end

  def create(person)
    hash_for(person)
  end

  private

  def rel(person)
    @relations.select { |x| x.person_id == person.id || x.persona_id == person.id }.each do |rel|
      r1 = @persons.find { |x| x.id == rel.persona_id }
      r2 = @persons.find { |x| x.id == rel.person_id }
      person.sex_id == 1 ? r1 : r2
    end
  end

  def childs(persons, person)
    chs = person.sex_id == 1 ? persons.where(father_id: person.id) : persons.where(mother_id: person.id)
    chs.present? ? chs.map { |ch| hash_for(ch) } : []
  end

  def hash_for(p)
    {
        sex_id: p.sex_id,
        name: p.full_name,
        children: childs(@persons, p),
        relations: [],
        person: p.attributes,
        info: p.info,
    }
  end
end
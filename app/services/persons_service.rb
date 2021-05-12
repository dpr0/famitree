# frozen_string_literal: true

class PersonsService

  attr_reader :persons

  def initialize(persons, relations, person_relations, persona_relations)
    @persons           = persons
    @relations         = relations
    @person_relations  = person_relations
    @persona_relations = persona_relations
  end

  def create(person)
    hash_for(person)
  end

  private

  def rel(person)
    @relations.select { |x| x.person_id == person.id || x.persona_id == person.id }.each do |rel|
      @persons.find { |x| x.id == (person.sex_id == Sex[:male].id ? rel.persona_id : rel.person_id) }
    end
  end

  def childs(person)
    chs = person.sex_id == Sex[:male].id ? @persons.select { |x| x.father_id == person.id } : @persons.select { |x| x.mother_id == person.id }
    chs.present? ? chs.map { |ch| hash_for(ch) } : []
  end

  def hash_for(p)
    relations = p.sex_id == Sex[:male].id ? @person_relations.select { |x| x.person_id == p.id } : @persona_relations.select { |x| x.persona_id == p.id }
    rel_str = relations.map { |rel| "#{relation_name(rel.relation_type_id)} с #{(p.sex_id == Sex[:male].id ? @persons.find { |x| x.id == rel.persona_id } : @persons.find { |x| x.id == rel.person_id }).fio_name}" }
    {
        sex_id: p.sex_id,
        name: p.fio_name,
        children: childs(p),
        relations: rel_str.last,
        person: p.attributes,
        info: p.info
    }
  end

  def relation_name(rel_type_id)
    rel_type_id == RelationType[:married].id ? RelationType[:married].name : RelationType[:divorced].name
  end
end

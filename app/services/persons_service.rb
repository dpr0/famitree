# frozen_string_literal: true

class PersonsService
  attr_reader :persons

  def initialize(persons, relations)
    @persons   = persons
    @relations = relations
  end

  def graph(person)
    hash_for(person)
  end

  def only_predki(ids)
    @predki = []
    predki(ids)
    @predki
  end

  private

  def hash_for(person)
    relations = @relations.select { |x| x.person_id == person.id || x.persona_id == person.id }
    relations_ids = person.sex_id == Sex[:male].id ? relations.map(&:persona_id) : relations.map(&:person_id)
    r_persons = @persons.select { |pp| relations_ids.include? pp.id }
    rel_str = relations_ids.map { |id| "#{relation_name(rel_type_by(person.id, id))} с #{@persons.find { |x| x.id == id }.fio_name}" }
    @predki = []
    r_persons.present? ? predki(r_persons.map(&:parent_ids).flatten) : []
    rel_predki = @persons.select { |pp| @predki.include? pp.id }.map { |pp| { last_name: pp.last_name, id: pp.id } }
    {
        sex_id:    person.sex_id,
        name:      person.fio_name,
        full_name: person.full_name,
        children:  childs(person),
        relations: rel_str.last,
        address:   person.address,
        info:      person.info,
        dates:     person.dates,
        avatar:    person.url_for_avatar,
        url:       "/persons/#{person.id}",
        rel_predki: rel_predki
    }
  end

  def childs(person)
    chs = @persons.select { |x| (person.sex_id == Sex[:male].id ? x.father_id : x.mother_id) == person.id }
    chs.present? ? chs.map { |ch| hash_for(ch) } : []
  end

  def rel_type_by(id1, id2)
    @relations.find { |x| (x.person_id == id1 && x.persona_id == id2) || (x.person_id == id2 && x.persona_id == id1) }&.relation_type_id
  end

  def predki(ids)
    ids.compact.map do |id|
      person = @persons.find { |p| p.id == id }
      next unless person

      father = @persons.find { |p| p.id == person.father_id } if person.father_id
      mother = @persons.find { |p| p.id == person.mother_id } if person.mother_id
      @predki << person.id if person.father_id.nil? && person.mother_id.nil?
      predki([father&.father_id, father&.mother_id, mother&.father_id, mother&.mother_id])
    end
  end

  def relation_name(rel_type_id)
    RelationType[rel_type_id == RelationType[:married].id ? :married : :divorced].name
  end
end

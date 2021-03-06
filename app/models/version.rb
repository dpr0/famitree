# frozen_string_literal: true

class Version < ApplicationRecord

  def self.prepare(event_type, ft_id, current_user, model, new_attrs)
    # new_attrs = new_attrs.to_h.symbolize_keys
    model_id = model.id
    model = model.class.new if event_type == 'create'
    old_attrs = model.attributes.slice(*new_attrs.keys)
    result = old_attrs.empty? ? new_attrs : {}
    old_attrs.each do |k, val|
      new_attrs[k] = new_attrs[k].to_date if val.instance_of? Date
      new_attrs[k] = new_attrs[k].to_i if k[-3..-1] == '_id'
      result[k] = new_attrs[k] if new_attrs[k] != val
    end
    new(family_tree_id: ft_id, person_id: current_user.person.id, model: model.class.name, model_id: model_id, model_changes: result, event_type: event_type)
  end

  def add
    save if model_changes.present?
  end

  def self.changes(model)
    where(model: model.class.name, model_id: model.id, deleted_at: nil).order(created_at: :desc)
  end
end

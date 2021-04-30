# frozen_string_literal: true

class Version < ApplicationRecord

  def self.prepare(ft_id, current_user_id, model, new_attrs)
    old_attrs = model.attributes.slice(*new_attrs.keys)
    result = {}
    old_attrs.each do |k, v|
      new_attrs[k] = new_attrs[k].to_date if v.instance_of? Date
      result[k] = new_attrs[k] if new_attrs[k] != v
    end
    new(family_tree_id: ft_id, user_id: current_user_id, model: model.class.name, model_id: model.id, model_changes: result)
  end

  def add
    save if model_changes.present?
  end

  def self.changes(model)
    where(model: model.class.name, model_id: model.id).order(created_at: :desc)
  end
end

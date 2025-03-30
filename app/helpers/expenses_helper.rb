module ExpensesHelper
  def category_color(category)
    colors = {
      'supplies' => '#4F46E5',      # Indigo
      'utilities' => '#10B981',     # Emerald
      'rent' => '#F59E0B',          # Amber
      'salaries' => '#EF4444',      # Red
      'maintenance' => '#6366F1',   # Indigo
      'marketing' => '#EC4899',     # Pink
      'transportation' => '#8B5CF6', # Violet
      'taxes' => '#F97316',         # Orange
      'other' => '#6B7280'          # Gray
    }

    colors[category.to_s] || '#6B7280'
  end

  def category_badge_class(category)
    classes = {
      'supplies' => 'bg-indigo-100 text-indigo-800',
      'utilities' => 'bg-emerald-100 text-emerald-800',
      'rent' => 'bg-amber-100 text-amber-800',
      'salaries' => 'bg-red-100 text-red-800',
      'maintenance' => 'bg-indigo-100 text-indigo-800',
      'marketing' => 'bg-pink-100 text-pink-800',
      'transportation' => 'bg-violet-100 text-violet-800',
      'taxes' => 'bg-orange-100 text-orange-800',
      'other' => 'bg-gray-100 text-gray-800'
    }

    classes[category.to_s] || 'bg-gray-100 text-gray-800'
  end
end

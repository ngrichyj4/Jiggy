class Comment
	include ParseModel::Model

	fields :content, :user, :post_id
end
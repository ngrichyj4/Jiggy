class Post
	include ParseModel::Model

	fields :content, :media, :caption, :location, :user, :likes, :commentCount
end
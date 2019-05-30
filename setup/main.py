import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('movie')

movies = [
    {
        'id': 1,
        'name': 'John Wick 3',
        'img_url': 'https://m.media-amazon.com/images/M/MV5BMDg2YzI0ODctYjliMy00NTU0LTkxODYtYTNkNjQwMzVmOTcxXkEyXkFqcGdeQXVyNjg2NjQwMDQ@._V1_UX140_CR0,0,140,209_AL_.jpg'
    },
    {
        'id': 2,
        'name': 'Avengers - Endgame',
        'img_url': 'https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_UY209_CR0,0,140,209_AL_.jpg'
    },
    {
        'id': 3,
        'name': 'Captain Marvel',
        'img_url': 'https://m.media-amazon.com/images/M/MV5BMTE0YWFmOTMtYTU2ZS00ZTIxLWE3OTEtYTNiYzBkZjViZThiXkEyXkFqcGdeQXVyODMzMzQ4OTI@._V1_UY209_CR0,0,140,209_AL_.jpg'
    },
    {
        'id': 4,
        'name': 'Dumbo',
        'img_url': 'https://m.media-amazon.com/images/M/MV5BNjMxMDE0MDI1Ml5BMl5BanBnXkFtZTgwMzExNTU3NjM@._V1_UY209_CR0,0,140,209_AL_.jpg'
    },
    {
        'id': 5,
        'name': 'Dark Phoenix',
        'img_url': 'https://m.media-amazon.com/images/M/MV5BMjAwNDgxNTI0M15BMl5BanBnXkFtZTgwNTY4MDI1NzM@._V1_UX140_CR0,0,140,209_AL_.jpg'
    }
]

for movie in movies:
    response = table.put_item(
        Item={
            'id': movie['id'],
            'name': movie['name'],
            'img_url': movie['img_url']
        }
    )

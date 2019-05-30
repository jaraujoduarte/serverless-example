
var app = new Vue({
    'el': '#app',
    'data': {
        'movies': [
            {
                title: 'John Wick',
                img_url: 'https://m.media-amazon.com/images/M/MV5BMDg2YzI0ODctYjliMy00NTU0LTkxODYtYTNkNjQwMzVmOTcxXkEyXkFqcGdeQXVyNjg2NjQwMDQ@._V1_UX182_CR0,0,182,268_AL_.jpg'
            },
            {
                title: 'Avengers - End Game',
                img_url: 'https://m.media-amazon.com/images/M/MV5BMjMxNjY2MDU1OV5BMl5BanBnXkFtZTgwNzY1MTUwNTM@._V1_UX182_CR0,0,182,268_AL_.jpg'
            }
        ],
        'options': [
            {value: 1, description: 'Mala'},
            {value: 2, description: 'Muah'},
            {value: 3, description: 'Normal'},
            {value: 4, description: 'Buena'},
            {value: 5, description: 'Excelente'}
        ]
    }
})


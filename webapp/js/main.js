const API_URL = 'https://jbv064p906.execute-api.us-east-1.amazonaws.com/default'

var app = new Vue({
    'el': '#app',
    'data': {
        'movies': [],
        'options': [
            {value: 1, description: 'Mala'},
            {value: 2, description: 'Muah'},
            {value: 3, description: 'Normal'},
            {value: 4, description: 'Buena'},
            {value: 5, description: 'Excelente'}
        ],
        'ratings': {}
    },
    'methods': {
        sendRatings: function(){
            axios
            .post(API_URL + '/rating', {ratings: this.ratings})
            .then(response => {
                console.log(response)
            });
        },
        addRating: function(event) {
            movieId = event.srcElement.name.split('-')[1]
            movieRating = event.srcElement.value
            this.ratings[movieId] = movieRating
        }
    },
    mounted () {
        axios
        .get(API_URL + '/movie')
        .then(response => {
            this.movies = eval(response.data)
            this.movies.forEach(element => {
                this.ratings[element.id] = 0
            });
        });
    }
})

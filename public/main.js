
function closeSideBar() {
    $('#sidebar').animate({
        left: "-15vw"
    }, 500)
}

function openSideBar() {
    $('#sidebar').animate({
        left: "0vw"
    }, 500)

}

function toggleDropdown() {
    let toggle = $('#dropdown-toggle');
    $('.dropdown-btn').toggle();
    const $image = $('#dropdown-toggle > img')
    if (toggle.data('toggle')) {
        $image.attr("src", "/icons/dropdown.svg")
        toggle.data('toggle', false);
    } else {
        $image.attr("src", "/icons/dropup.svg")
        toggle.data('toggle', true);
    }
}
function openDeletePopup(teamId, tournamentId, playerId) {
    let $deletePopup = $('#delete-popup');
    $deletePopup.css({'display': 'block', 'opacity': '0', 'top': '60%'});
    $deletePopup.animate({
        'opacity': '100%',
        'top': '30%'
    }, 700)
    $('#delete-btn').attr({'href': `/teams/${teamId}/${tournamentId}/delete/${playerId}`})
}

function closeDeletePopup() {
    let $deletePopup = $('#delete-popup');
    $deletePopup.animate({
        'opacity': '0%',
        'top': '60%'
    }, 400)
    $('#delete-btn').attr({'href': ''});
}

function getMostActiveTeam() {
    fetch('http://localhost:3000/mostActiveTeam').then((res) => res.json()).then(({mostActiveTeam}) => {
        if (mostActiveTeam.length) {
            const ids = mostActiveTeam.map((teams) => {
                return teams['team_id'];
            })
            const teams = ids.map((id) => {
                return $('#team_' + id);
            });
            let ready = false;
            setTimeout(() => {
                ready = true;
            }, 3000);

            function blink() {
                teams.forEach((team) => {
                    team.css({'background-color': 'white'})
                    team.fadeOut('slow', function() {
                        $(this).fadeIn('slow', function() {
                            if (!ready) {
                                blink();
                            } else {
                                team.css({'background-color': 'orange'})
                            }
                        });
                    })
                })
            }
            blink();

        }
    });
}
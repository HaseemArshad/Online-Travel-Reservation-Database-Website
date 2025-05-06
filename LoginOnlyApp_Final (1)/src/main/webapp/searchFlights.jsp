<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <title>Search Flights</title>
    <script>
      window.addEventListener('DOMContentLoaded', function(){
        const oneWay = document.getElementById('tripOneWay');
        const round  = document.getElementById('tripRound');
        const ret    = document.getElementById('returnDate');

        function toggleReturn() {
          if (round.checked) {
            ret.disabled = false;
            ret.required = true;
          } else {
            ret.disabled = true;
            ret.required = false;
            ret.value = '';
          }
        }

        oneWay.addEventListener('change', toggleReturn);
        round.addEventListener('change', toggleReturn);

        // init on load
        toggleReturn();
      });
    </script>
</head>
<body>
    <h2>Search for Flights</h2>
    <form action="searchFlights" method="post">

        Trip Type:
        <label>
          <input type="radio" id="tripOneWay"  name="tripType" value="oneway"  checked>
          One-way
        </label>
        <label>
          <input type="radio" id="tripRound"   name="tripType" value="roundtrip">
          Round-trip
        </label>
        <br><br>

        From Airport Code:
        <input type="text" name="fromAirport" required><br><br>

        To Airport Code:
        <input type="text" name="toAirport" required><br><br>

        Departure Date (YYYY-MM-DD):
        <input type="text" name="departureDate" required><br><br>

        Return Date (YYYY-MM-DD):
        <input type="text" id="returnDate" name="returnDate"><br><br>

        <input type="submit" value="Search Flights">
    </form>
</body>
</html>

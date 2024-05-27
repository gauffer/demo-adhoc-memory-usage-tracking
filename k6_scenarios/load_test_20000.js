import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 1000, // Number of virtual users
  duration: '10s', // Duration of the test
  rps: 20000, // Requests per second
};

export default function () {
  const res = http.get('http://127.0.0.1:8080/');
  check(res, {
    'is status 200': (r) => r.status === 200,
  });
}



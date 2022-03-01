package controller

import (
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/ybkuroki/go-webapp-sample/test"
	"github.com/ybkuroki/go-webapp-sample/util"
	"go.uber.org/zap/zaptest/observer"
)

func TestLogging(t *testing.T) {
	router, container, logs := test.PrepareForLoggerTest()

	book := NewBookController(container)
	router.GET(APIBooksID, func(c echo.Context) error { return book.GetBook(c) })

	setUpTestData(container)

	uri := util.NewRequestBuilder().URL(APIBooks).PathParams("1").Build().GetRequestURL()
	req := httptest.NewRequest("GET", uri, nil)
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	allLogs := logs.All()
	assert.True(t, assertLogger("/api/books/:id Action Start", allLogs))
	assert.True(t, assertLogger("/api/books/:id Action End", allLogs))
	assert.True(t, assertLogger("/api/books/1 GET 200", allLogs))
	assert.True(t, assertLogger("[gorm] select b.*, c.id as category_id, c.name as category_name, f.id as format_id, f.name as format_name from book b inner join category_master c on c.id = b.category_id inner join format_master f on f.id = b.format_id  where b.id = 1", allLogs))
}

func assertLogger(message string, logs []observer.LoggedEntry) bool {
	for _, l := range logs {
		if strings.Contains(l.Message, message) {
			return true
		}
	}
	return false
}

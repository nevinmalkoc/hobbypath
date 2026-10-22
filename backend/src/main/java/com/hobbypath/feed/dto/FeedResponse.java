package com.hobbypath.feed.dto;

import com.hobbypath.event.dto.EventResponse;
import com.hobbypath.post.dto.PostResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeedResponse {

    private List<PostResponse> communityPosts;
    private List<EventResponse> upcomingEvents;
}
